# Web Setup Instructions for Pengaduan App

To make image uploads work correctly in the web version of the Aplikasi Pengaduan, follow these instructions:

## CORS Issues with File Uploads

When running the Flutter web app, image uploads might fail due to Cross-Origin Resource Sharing (CORS) restrictions. The app has been updated to use relative URLs (`/api/*`) instead of absolute URLs, but you need to properly configure the development environment.

## Option 1: Using a Proxy for Development

### Setup with Flutter Dev Server and Laravel

1. Start your Laravel backend server as usual on port 8000:
   ```
   cd /path/to/your/laravel/project
   php artisan serve
   ```

2. Run your Flutter app with the `--web-renderer html` and specify a port:
   ```
   flutter run -d chrome --web-renderer html --web-port=8080
   ```

3. Set up a proxy in your web server (like Nginx or Apache) or use a development proxy like `http-proxy-middleware` to forward requests from `/api/*` to your Laravel server.

### Using Laravel Valet (macOS)

If you're using Laravel Valet on macOS, you can serve your Laravel application at a custom domain like `pengaduan.test` and modify your Flutter app's `index.html` to include a base tag:

```html
<head>
  <base href="http://pengaduan.test/">
  <!-- other head content -->
</head>
```

## Option 2: Configure Laravel CORS Settings

If you want to allow direct communication between your Flutter web app and Laravel backend:

1. In your Laravel project, install the CORS package if it's not already installed:
   ```
   composer require fruitcake/laravel-cors
   ```

2. Configure CORS in your `config/cors.php` file:
   ```php
   return [
       'paths' => ['api/*'],
       'allowed_methods' => ['*'],
       'allowed_origins' => ['http://localhost:8080'], // Add your Flutter web app URL
       'allowed_origins_patterns' => [],
       'allowed_headers' => ['*'],
       'exposed_headers' => [],
       'max_age' => 0,
       'supports_credentials' => true, // Important for auth cookies
   ];
   ```

3. Make sure your `Kernel.php` has the CORS middleware:
   ```php
   protected $middleware = [
       // ...
       \Fruitcake\Cors\HandleCors::class,
   ];
   ```

## Option 3: Use a Production Build for Testing

For testing in a production-like environment:

1. Build your Flutter web app:
   ```
   flutter build web
   ```

2. Copy the contents of the `build/web` directory to your Laravel project's `public` directory or to the appropriate web server directory.

3. Access your app through the Laravel server directly (e.g., http://localhost:8000).

## Notes on Image Upload Field Names

The API expects the file upload field to be named `foto`. This is correctly configured in the app code.

If you encounter issues with image uploads showing as `null` in the database, check your Laravel controller to ensure it's processing the `foto` field correctly, and your database migration includes the correct field name.

For debugging, check both browser's network tab and your Laravel logs to see if there are any issues with file handling.
