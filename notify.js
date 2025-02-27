const { IncomingWebhook } = require("@slack/webhook");
require("dotenv").config();

const webhookUrl = `https://hooks.slack.com/services/${process.env.SLACK_WEB_HOOK}`;
const webhook = new IncomingWebhook(webhookUrl);

async function notifySlack(message, date) {
  try {
    await webhook.send({
      text: message,
      attachments: [
        {
          text: date,
          color: "#00FF00",
        },
      ],
    });
    console.log("Notification sent to Slack!");
  } catch (error) {
    console.error("Error sending to Slack:", error);
  }
}

notifySlack(
  `Backup database ${process.env.DB_NAME} completed! :rocket:`,
  `Success on: ${new Date().toISOString()}`
);
