import os
import logging
from slack_bolt import App
from slack_bolt.adapter.socket_mode import SocketModeHandler
from slack_sdk import WebClient
from jira import JIRA
from dotenv import load_dotenv

# Set up logging
logging.basicConfig(level=logging.DEBUG)
logger = logging.getLogger(__name__)

# Load environment variables from .env file
load_dotenv()
logger.debug("Environment variables loaded")

# Initialize the Slack app and web client
app = App(token=os.environ["SLACK_BOT_TOKEN"])
client = WebClient(token=os.environ["SLACK_BOT_TOKEN"])
logger.debug("Slack app and web client initialized")

# Initialize Jira client
try:
    jira = JIRA(
        server=os.environ["JIRA_SERVER"],
        basic_auth=(os.environ["JIRA_EMAIL"], os.environ["JIRA_API_TOKEN"])
    )
    logger.debug("Jira client initialized")
except Exception as e:
    logger.error(f"Failed to initialize Jira client: {e}")

# Counter for ticket numbering
ticket_counter = 1

# List of allowed channel IDs
ALLOWED_CHANNELS = os.environ.get("ALLOWED_CHANNELS", "").split(",")
logger.debug(f"Allowed channels: {ALLOWED_CHANNELS}")

# Jira server URL for ticket links
JIRA_SERVER = os.environ["JIRA_SERVER"]

def get_full_message(channel_id, message_ts):
    try:
        result = client.conversations_history(
            channel=channel_id,
            latest=message_ts,
            limit=1,
            inclusive=True
        )
        if result["ok"] and len(result["messages"]) > 0:
            message = result["messages"][0]
            message_text = message.get("text", "")
            
            # Get permalink
            permalink = client.chat_getPermalink(
                channel=channel_id,
                message_ts=message_ts
            )["permalink"]
            
            return message_text, permalink
        else:
            logger.error("Failed to fetch message details")
            return None, None
    except Exception as e:
        logger.error(f"Error fetching message details: {e}")
        return None, None

@app.event("reaction_added")
def handle_reaction(event, say):
    global ticket_counter
    logger.debug(f"Reaction event received: {event}")
    
    channel_id = event["item"]["channel"]
    
    # Check if the event occurred in an allowed channel
    if ALLOWED_CHANNELS and channel_id not in ALLOWED_CHANNELS:
        logger.warning(f"Reaction event in non-allowed channel: {channel_id}")
        return
    
    if event["reaction"] == "jira":
        logger.info("Jira reaction detected, processing...")
        # Get the message that was reacted to
        message_ts = event["item"]["ts"]
        
        try:
            message_text, permalink = get_full_message(channel_id, message_ts)
            if message_text is None or permalink is None:
                logger.error("Failed to get full message content or permalink")
                say("Sorry, I couldn't create a Jira ticket due to an error fetching the message content.")
                return

            logger.info(f"Full message content: {message_text}")
            logger.info(f"Message permalink: {permalink}")
            
            # Create Jira ticket
            issue_dict = {
                'project': {'key': os.environ["JIRA_PROJECT_KEY"]},
                'summary': f'CDE-HELP-{ticket_counter}',
                'description': f"Slack message: {permalink}\n\nFull message content:\n{message_text}",
                'issuetype': {'name': 'Task'},
            }
            
            new_issue = jira.create_issue(fields=issue_dict)
            logger.info(f"Jira ticket created: {new_issue.key}")
            
            # Increment the ticket counter
            ticket_counter += 1
            
            # Notify in the Slack channel with Jira ticket link
            jira_ticket_link = f"{JIRA_SERVER}/browse/{new_issue.key}"
            say(f"Jira ticket created: <{jira_ticket_link}|{new_issue.key}>")
        except Exception as e:
            logger.error(f"Error processing reaction: {e}")
            say("Sorry, an error occurred while creating the Jira ticket.")
    else:
        logger.debug(f"Non-jira reaction: {event['reaction']}")

@app.event("message")
def handle_message(message, say):
    logger.debug(f"Message event received: {message}")

if __name__ == "__main__":
    logger.info("Starting the Slack bot...")
    handler = SocketModeHandler(app, os.environ["SLACK_APP_TOKEN"])
    handler.start()