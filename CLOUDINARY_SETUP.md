# Cloudinary Setup Instructions

## Setting Up Unsigned Upload Preset

To enable image uploads in the app, you need to create an unsigned upload preset in Cloudinary:

### Steps:

1. **Go to Cloudinary Dashboard**
   - Visit: https://cloudinary.com/console
   - Login with your account

2. **Navigate to Upload Settings**
   - Click on the **Settings** icon (gear icon) in the top right
   - Go to the **Upload** tab
   - Scroll down to **Upload presets**

3. **Create a New Upload Preset**
   - Click **Add upload preset**
   - Set the following:
     - **Upload preset name**: `todolist_unsigned`
     - **Signing Mode**: Select **Unsigned**
     - **Folder**: `profile_photos` (optional but recommended)
     - **Access mode**: Public (default)
     - Leave other settings as default

4. **Save the Preset**
   - Click **Save**

### Alternative: Use Signed Upload

If you prefer not to use unsigned uploads, the app also includes a `uploadImageSigned()` method. To use it:

1. Update `SettingsViewModel.swift`:
   ```swift
   // Change this line in uploadProfilePhoto():
   let imageUrl = try await CloudinaryService.shared.uploadImageSigned(image)
   ```

### Testing

After setting up the upload preset:
1. Run the app
2. Go to Settings → Personal Info
3. Click "Change" on the profile photo
4. Select "Upload Photo"
5. Choose an image and crop it
6. The image should upload successfully

### Troubleshooting

If uploads still fail, check the Xcode console for error messages. The app now logs:
- HTTP status codes
- Cloudinary error messages
- Network errors

Common issues:
- **401 Unauthorized**: Check that upload preset name matches exactly
- **400 Bad Request**: Verify the upload preset is set to "Unsigned"
- **Network Error**: Check internet connection
