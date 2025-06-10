const express = require('express');
const path = require('path');
const app = express();

app.use(express.static(path.join(__dirname, '../client/build')));

app.get('/api', (req, res) => {
  res.json({ message: "Hello from the backend!" });
});

const indexPath = path.resolve(__dirname, '../client/build/index.html');

app.get('*', (req, res) => {
  res.sendFile(indexPath);
});

app.listen(3000, '0.0.0.0', () => {
  console.log('Server running on port 3000');
});
