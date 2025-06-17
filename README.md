# Dream Analyzer AI 🌙

A beautiful Flutter mobile app that uses artificial intelligence to analyze your dreams and provide personalized insights and advice.

## Features ✨

### 🤖 AI-Powered Dream Analysis
- Advanced dream interpretation using OpenAI's GPT models
- Personalized psychological insights
- Meaningful advice based on dream content

### 📱 Beautiful Mobile Interface
- Modern, intuitive design with gradient themes
- Smooth animations and transitions
- Responsive layout for all screen sizes

### 📚 Dream History
- Save and view all your past dream analyses
- Beautiful card-based history view
- Tap to revisit any previous analysis

### 🎯 Smart Features
- Real-time server status checking
- Native share functionality
- Comprehensive dream writing tips
- Offline-ready design

### 🔗 Integrated Backend
- Flask REST API with SQLite database
- Secure OpenAI API integration
- RESTful endpoints for all operations

## Screenshots 📸

*Add screenshots here showing the main screens of the app*

## Prerequisites 📋

Before running this app, make sure you have:

- Flutter SDK (3.8.0 or higher)
- Dart SDK
- Python 3.8+ (for backend)
- OpenAI API key
- Android Studio or VS Code
- Android emulator or physical device

## Setup Instructions 🚀

### 1. Clone the Repository
```bash
git clone <repository-url>
cd dream-analyzer
```

### 2. Setup Flutter Dependencies
```bash
flutter pub get
```

### 3. Setup Backend

Navigate to the backend directory:
```bash
cd backend
```

Install Python dependencies:
```bash
pip install flask flask-cors openai python-dotenv
```

Create a `.env` file in the backend directory:
```env
OPENAI_API_KEY=your_openai_api_key_here
```

### 4. Run the Backend Server
```bash
python app.py
```

The server will start on `http://localhost:5000`

### 5. Run the Flutter App
```bash
flutter run
```

## API Endpoints 🔌

### POST /analyze-dream
Analyze a dream text and return AI-generated insights.

**Request:**
```json
{
  "dream_text": "I was flying over a beautiful landscape...",
  "user_id": "anonymous"
}
```

**Response:**
```json
{
  "success": true,
  "dream_id": 1,
  "dream_text": "I was flying over a beautiful landscape...",
  "analysis": "AI analysis of the dream...",
  "advice": "Personalized advice based on the dream...",
  "timestamp": "2024-01-01T12:00:00"
}
```

### GET /dream-history
Retrieve user's dream history.

**Parameters:**
- `user_id` (optional): User identifier (default: "anonymous")
- `limit` (optional): Number of dreams to return (default: 10)

### GET /health
Check server health status.

## Project Structure 📁

```
dream-analyzer/
├── lib/
│   ├── main.dart                 # App entry point
│   ├── models/
│   │   └── dream_analysis.dart   # Data models
│   ├── screens/
│   │   ├── home_screen.dart      # Main input screen
│   │   ├── analysis_screen.dart  # Dream analysis display
│   │   ├── history_screen.dart   # Dream history view
│   │   └── tips_screen.dart      # Dream writing tips
│   └── services/
│       └── dream_service.dart    # API communication
├── backend/
│   ├── app.py                    # Flask backend server
│   └── dreams.db                 # SQLite database
└── pubspec.yaml                  # Flutter dependencies
```

## Technologies Used 🛠️

### Frontend
- **Flutter** - Cross-platform mobile development
- **Dart** - Programming language
- **Provider** - State management
- **HTTP** - API communication
- **Share Plus** - Native sharing functionality
- **Intl** - Internationalization

### Backend
- **Flask** - Python web framework
- **SQLite** - Lightweight database
- **OpenAI API** - AI-powered dream analysis
- **Flask-CORS** - Cross-origin resource sharing

## Contributing 🤝

1. Fork the repository
2. Create a feature branch (`git checkout -b feature/amazing-feature`)
3. Commit your changes (`git commit -m 'Add amazing feature'`)
4. Push to the branch (`git push origin feature/amazing-feature`)
5. Open a Pull Request

## Future Enhancements 🔮

- [ ] User authentication and personal accounts
- [ ] Dream categories and tags
- [ ] Advanced dream analytics and trends
- [ ] Push notifications for dream reminders
- [ ] Export dreams to PDF/email
- [ ] Dream sharing with friends
- [ ] Offline mode with local storage
- [ ] Multiple language support
- [ ] Dark mode theme
- [ ] Voice input for dreams

## License 📄

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## Support 💬

If you encounter any issues or have questions:

1. Check the [Issues](../../issues) section
2. Create a new issue with detailed information
3. Contact the development team

## Acknowledgments 🙏

- OpenAI for providing the GPT API
- Flutter team for the amazing framework
- All contributors and testers

---

Made with ❤️ by the Dream Analyzer Team 