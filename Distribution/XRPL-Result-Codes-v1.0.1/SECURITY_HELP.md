# 🚨 IMPORTANT: Security Warning Fix

## If you see "XRPLResultCodes is damaged and can't be opened"

**This is NORMAL for apps downloaded from GitHub. The app is NOT actually damaged.**

## ✅ QUICK FIX (Choose One):

### Method 1: Use the Fix Script (Easiest)
```bash
# In Terminal, navigate to this folder and run:
chmod +x fix-security.sh
./fix-security.sh
```

### Method 2: Right-Click Method
1. **Right-click** on `XRPLResultCodes.app`
2. Select **"Open"** from the menu
3. Click **"Open"** when macOS warns you
4. The app will launch and be trusted forever

### Method 3: Command Line
```bash
# Remove the quarantine flag:
xattr -dr com.apple.quarantine XRPLResultCodes.app

# Then launch:
open XRPLResultCodes.app
```

### Method 4: Enhanced Installer
```bash
# Run the enhanced installer:
chmod +x install.sh
./install.sh
```

---

## Why This Happens

macOS blocks apps from unidentified developers by default. This is a security feature, not an actual problem with the app.

## The App is Safe

- ✅ Open source code available on GitHub
- ✅ No malware or harmful code
- ✅ Native Swift application
- ✅ Only connects to XRPL/Xahau networks for data

---

## After Fixing

Once you use any of the methods above, the app will:
1. 🎯 Appear in your **menu bar** (top-right of screen)
2. 📊 Show XRPL and Xahau transaction result codes
3. 🔄 Auto-refresh every 5 minutes
4. ⚡ Allow instant switching between networks

## Need Help?

Try the methods in order. Method 1 (fix-security.sh) usually works best.

**The app works perfectly once the security warning is bypassed!** 🚀