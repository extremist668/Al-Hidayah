# Complete Flutter Web Deployment Guide: Al-Hidayah

Publishing your Islamic app as a modern progressive web application (PWA) is a fantastic way to offer instant access to users on computers, tablets, and mobile devices without requiring Google Play Store installation.

---

## ⚡ Web-Specific Platform Adaptations Included

To support publishing on the web, the codebase has been modified with these safety measures:
1. **Web-Safe Main Entry:** Bypasses Android-only background `Workmanager` registrations on browsers to avoid launch crashes.
2. **Graceful Notifications Fallback:** Converts local scheduled alarms to clean console-logged triggers and is fully prepared for browser web push integrations.
3. **Responsive Compass Fallback:** If a device (like a desktop computer) does not have physical magnetometer compass hardware, the Qibla screen displays a beautiful explanatory banner while keeping GPS location coordinate calculations functional.

---

## 🚀 Option 1: Quick Deployment on Vercel (Recommended)

Vercel is completely free and optimized for hosting highly fast, secure static web application bundles.

### Step-by-Step Vercel Deployment:
1. Push your repository to your private or public GitHub profile.
2. Sign in to your [Vercel Dashboard](https://vercel.com).
3. Click **Add New > Project**, and import your GitHub repository.
4. **Configure Project Settings:**
   - **Framework Preset:** Select `Other` (or leave as default).
   - **Build Command:** `flutter/bin/flutter build web --release --web-renderer canvaskit`
   - **Output Directory:** `build/web`
5. Click **Deploy**. Vercel will build the app and give you a free, secure `https://your-project.vercel.app` domain!

---

## 🌐 Option 2: Deploy to GitHub Pages (Free Hosting)

GitHub Pages is another free alternative directly integrated into your project's code repository.

### Step-by-Step GitHub Pages Deployment:
1. Enable Pages on your GitHub repo: Go to **Settings > Pages**.
2. Set the Source to **GitHub Actions**.
3. Create a workflow file `.github/workflows/deploy_gh_pages.yml` and add a script to build web and push it to the `gh-pages` deployment branch:
   ```yaml
   name: Deploy to GitHub Pages
   on:
     push:
       branches: [ "main" ]
   jobs:
     deploy:
       runs-on: ubuntu-latest
       steps:
         - uses: actions/checkout@v4
         - uses: subosito/flutter-action@v2
           with:
             channel: 'stable'
             flutter-version: '3.19.x'
         - run: flutter pub get
         - run: flutter build web --release --base-href "/YOUR_REPO_NAME/"
         - name: Deploy
           uses: JamesIves/github-pages-deploy-action@v4
           with:
             folder: build/web
             branch: gh-pages
   ```
4. Push your changes. Your app will automatically publish to `https://yourusername.github.io/YOUR_REPO_NAME/`!

---

## 🛠️ Option 3: Local Compilation & Testing

Before uploading, you can compile and test the web app locally on your computer.

### Step 1: Build the Web App
Run the release compiler using your terminal:
```bash
flutter build web --release --web-renderer canvaskit
```
- `--web-renderer canvaskit` ensures that Islamic Arabic typography (Amiri) and Urdu Nastaliq calligraphy are rendered with absolute anti-aliasing precision on all screens.

### Step 2: Run a Local Web Server
Since browsers enforce strict Security/CORS origins, you must launch the index using a secure local server environment:

```bash
# Using Python
python -m http.server 8080 --directory build/web

# Or using Node.js
npx http-server build/web -p 8080
```
Open your browser and navigate to `http://localhost:8080` to experience the web app!

---

## ⚠️ Important Production Considerations

1. **HTTPS is Mandatory for Location Sensors:** Browsers strictly block Geolocation coordinate requests (`Geolocator.getCurrentPosition`) on unencrypted HTTP connections. Make sure your active hosting deployment utilizes **HTTPS** (Vercel, GitHub Pages, and Netlify provide secure HTTPS out of the box).
2. **Supabase Web Authentication:** Make sure to add your deployed web URL (e.g. `https://your-app.vercel.app`) as an authorized Redirect Origin inside your **Supabase Dashboard > Auth > URL Configuration**.
