# Simple Weather Desktop App

A modern, minimalistic weather desktop application built using Flutter. This app displays real-time weather conditions, temperature, air quality index (AQI), and humidity for any city entered.

## Features

- **City Search with Autocomplete**  
  Provides live city suggestions as you type.

- **Current Weather Information**  
  Displays temperature, weather condition, and location.

- **Air Quality Index (AQI)**  
  Visual indicator based on PM2.5 values with color-coded scale and numeric value.

- **Humidity Display**  
  Horizontal progress bar showing real-time humidity percentage.

- **Fixed Window Dimensions**  
  Set to 500x800 for a consistent desktop layout using the `window_manager` package.

- **Responsive Icons**  
  Dynamic weather icons based on current conditions (e.g., sunny, cloudy, rainy).

- **Gradient Background and Glass UI**  
  A visually clean background gradient to maintain focus on weather data.

## Demo Screenshots


- ![image](https://github.com/user-attachments/assets/f865a862-1ba5-491c-92ad-521f8d903345)
 — City search with suggestions dropdown  
- ![image](https://github.com/user-attachments/assets/39b66428-dca8-4229-bf95-33d1539e63d0)
 — Main weather display with AQI and temperature  

## Technologies Used

- Flutter 
- WeatherAPI.com (for real-time data)
- window_manager (for custom desktop window control)

## Getting Started

1. Clone the repository  
2. Run `flutter pub get`  
3. Replace `'YOUR_API_KEY'` with your API key from [weatherapi.com](https://www.weatherapi.com/)  
4. Run the app on Windows using `flutter run -d windows`

## Notes

- This app is currently built for Windows desktop only.
- All data is fetched using HTTP requests; ensure you have an internet connection.
