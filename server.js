const express = require('express');
const cors = require('cors');
const path = require('path');
const app = express();
const port = 3000;

// Enable CORS for all routes
app.use(cors());

// Serve static files from the web directory
app.use(express.static(path.join(__dirname, 'build/web')));

// Middleware to log all requests
app.use((req, res, next) => {
  console.log(`${new Date().toISOString()} - ${req.method} ${req.url}`);
  next();
});

// Handle OAuth callback and code parameter in any route
app.use((req, res, next) => {
  const code = req.query.code;
  if (code) {
    console.log('Auth code detected:', code);
    // Send HTML that posts the code to the Flutter app
    res.send(`
      <html>
        <body>
          <script>
            window.location.href = "io.supabase.fluttertodo://login-callback/?code=${code}";
          </script>
        </body>
      </html>
    `);
  } else {
    next();
  }
});

// Serve index.html for all other routes
app.get('*', (req, res) => {
  res.sendFile(path.join(__dirname, 'build/web/index.html'));
});

// Error handling middleware
app.use((err, req, res, next) => {
  console.error('Error:', err);
  res.status(500).json({ error: 'Internal Server Error' });
});

app.listen(port, '0.0.0.0', () => {
  console.log(`Server running at http://0.0.0.0:${port}`);
  console.log('Server accessible at:');
  console.log(`- http://localhost:${port}`);
  console.log(`- http://10.0.2.2:${port} (Android Emulator)`);
}); 