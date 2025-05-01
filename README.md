# NewsReaderApp
An iOS application for reading news using NewsAPI.

## Description
NewsReaderApp is an iOS application that allows users to read the latest news from various sources using NewsAPI. The app is designed using Clean Architecture and the MVVM pattern. Users can view, bookmark, and read detailed news articles.

## Features
- Displays a list of news from various sources.
- Ability to view full news articles with the author, publish date, and source.
- Bookmark functionality to save and remove news articles.
- Bottom navigation with two main sections: "News List" and "Bookmarks".
- Dark Mode support.

## Technologies Used
- **Swift** – Programming language for iOS development.
- **UIKit** – Framework for building the user interface.
- **CoreData** – Framework for saving and fetching bookmarked news.
- **NewsAPI** – API for fetching news from various sources.
- **Clean Architecture** – Architectural pattern for structuring the app.
- **MVVM** – Architectural pattern for managing data and UI logic.

## Functional Requirements
1. **News List Screen**: Displays a list of news from various sources with categories (Tab Layout). Each item should display the title, a brief description, and the source of the news.
2. **News Detail Screen**: When an item is tapped, the user sees the full news article with additional information such as the author and publish date. The user can save the news to Bookmarks or remove it from the bookmarks if it is already saved.
3. **Bookmarks Screen**: Displays a list of saved news articles.
4. **Navigation**: Bottom navigation with two sections: "News List" and "Bookmarks".

## Technical Requirements
1. **Clean Architecture**: The app is divided into three layers: data, domain, and presentation. The presentation layer is responsible only for UI-related logic.
2. **MVVM Architecture**: Each screen follows the MVVM pattern (Model-View-ViewModel) to separate business logic from UI logic.
3. **UIKit + SwiftUI**: The app is built using UIKit with support for dark mode.

## Additional Features (Optional)
1. **Error Handling**: The app handles network errors (e.g., no internet connection, data loading issues).
2. **News Caching**: Cached news articles are shown when there is no internet connection.
3. **Unit Tests**: Unit tests are written for the data and domain layers to ensure functionality.
