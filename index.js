const axios = require('axios');
const core = require('@actions/core');

async function run() {
  try {
    const webhookUrl = core.getInput('webhook_url');
    const tagName = core.getInput('tag_name');

    const data = {
      tag: tagName,
      // Add other data as needed
    };

    const response = await axios.post(webhookUrl, data);
    console.log('Webhook response:', response.data);
  } catch (error) {
    core.setFailed(error.message);
  }
}

run();