const formData = require('form-data');
  const Mailgun = require('mailgun.js');
  const mailgun = new Mailgun(formData);
  const mg = mailgun.client({username: 'api', key: process.env.MAILGUN_API_KEY || 'ca4f60cda9de575cd3027db9d7ea8248-91fbbdba-79f4ad96'});
  
  mg.messages.create('sandbox-123.mailgun.org', {
  	from: "Excited User <mailgun@sandbox2226bc1df4ec4c9da81dd02eb13315ca.mailgun.org>",
  	to: ["hosford@gmail.com"],
  	subject: "Hello",
  	text: "Testing some Mailgun awesomeness!",
  	html: "<h1>Testing some Mailgun awesomeness!</h1>"
  })
  .then(msg => console.log(msg)) // logs response data
  .catch(err => console.log(err)); // logs any error