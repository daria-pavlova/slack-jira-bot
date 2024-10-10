
# Slack Bot and Jira Integration

## Slack Bot Token and App Token:

### a) Create a Slack App:
1. Go to [Slack API](https://api.slack.com/apps).
2. Click "Create New App" and choose "From scratch".
3. Name your app and select your workspace.

### b) Configure your app:
1. Under "Add features and functionality", select "Bots".
2. Click "Review Scopes to Add" under "Scopes".
3. Add the following OAuth scopes:
   - `channels:history`
   - `chat:write`
   - `reactions:read`

### c) Install the app to your workspace:
1. Go to "Install App" in the sidebar.
2. Click "Install to Workspace".

### d) Get the Bot Token:
1. After installation, you'll see a "Bot User OAuth Token".
2. This is your `SLACK_BOT_TOKEN`.

### e) Enable Socket Mode and get the App Token:
1. Go to "Socket Mode" in the sidebar and enable it.
2. You'll be prompted to generate an App-Level Token.
3. Give it a name and add the scope `connections:write`.
4. The generated token is your `SLACK_APP_TOKEN`.

---

## Jira API Token and Project Key:

### a) Generate an API token:
1. Log in to [Atlassian](https://id.atlassian.com/manage/api-tokens).
2. Click "Create API token".
3. Give it a label and click "Create".
4. Copy the generated token - this is your `JIRA_API_TOKEN`.

### b) Get your Jira email:
1. This is the email you use to log in to Jira.
2. It will be your `JIRA_EMAIL`.

### c) Find your Jira server URL:
1. This is typically in the format `https://your-domain.atlassian.net`.
2. It will be your `JIRA_SERVER`.

### d) Get your Jira project key:
1. In Jira, go to your project.
2. The project key is usually visible in the URL or in the project details (e.g., "PROJ" or "CDE").
3. This will be your `JIRA_PROJECT_KEY`.

---

## Configure your .env file:

```plaintext
SLACK_BOT_TOKEN=xoxb-your-bot-token
SLACK_APP_TOKEN=xapp-your-app-token
JIRA_SERVER=https://your-domain.atlassian.net
JIRA_EMAIL=your-email@example.com
JIRA_API_TOKEN=your-jira-api-token
JIRA_PROJECT_KEY=YOUR_PROJECT_KEY
ALLOWED_CHANNELS=C012345678,C987654321
```

---

## Add necessary scopes to your Slack app:

1. Go to your Slack App's configuration page: [Slack API](https://api.slack.com/apps).
2. Select your app.
3. Navigate to "OAuth & Permissions" in the sidebar.
4. Under "Scopes", add the following Bot Token Scopes:
   - `channels:history`
   - `chat:write`
   - `reactions:read`
   - `channels:read`

### Reinstall your app:
After adding new scopes, you need to reinstall your app to your workspace:
1. Go to "Install App" in the sidebar and click "Reinstall to Workspace".

### Invite the bot to specific channels:
1. In Slack, go to the channel where you want the bot to operate.
2. Type `/invite @YourBotName` (replace `YourBotName` with your actual bot's name).
3. The bot will now be a member of that channel and can read messages and reactions.

---

## Update your bot code:

Your current bot code listens for the `reaction_added` event globally. To restrict it to specific channels:

1. Add an `ALLOWED_CHANNELS` list populated from an environment variable.
2. The `handle_reaction` function should check if the channel where the reaction was added is in the `ALLOWED_CHANNELS` list.

### Example:

Update your `.env` file or Kubernetes secret to include the `ALLOWED_CHANNELS` variable:
```plaintext
ALLOWED_CHANNELS=C012345678,C987654321
```

You can get channel IDs using the [Slack API tester](https://api.slack.com/methods/conversations.list/test).

### Rebuild your Docker image:
Rebuild your Docker image and redeploy to Minikube.

---

Remember to invite your bot to all the channels listed in `ALLOWED_CHANNELS`.

## To build the container for minikuhe:
1. eval $(minikube docker-env)
2. docker build -t .
3. docker push
