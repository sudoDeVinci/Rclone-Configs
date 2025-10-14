# How to Set Up Google Drive with Rclone

## Step 1: Install Rclone on Your Ugreen NAS

```bash
# SSH into your NAS, then:
sudo apt-get update
sudo apt-get install rclone
```

## Step 2: Run Rclone Config

```bash
rclone config
```

## Step 3: Follow the Interactive Setup

You'll see a menu. Here's what to choose:

### 3.1 Create New Remote
```
No remotes found, make a new one?
n) New remote
s) Set configuration password
q) Quit config
n/s/q> n
```
Type: **n** and press Enter

### 3.2 Name Your Remote
```
Enter name for new remote.
name> gdrive
```
Type: **gdrive** (or any name you prefer) and press Enter

### 3.3 Choose Storage Type
```
Type of storage to configure.
Choose a number from below, or type in your own value.
...
22 / Google Drive
   \ (drive)
...
Storage> 22
```
Type: **22** (the number for Google Drive) and press Enter

### 3.4 Google Application Client ID
```
Google Application Client Id
Setting your own is recommended.
See https://rclone.org/drive/#making-your-own-client-id for how to create your own.
If you leave this blank, it will use an internal key which is low performance.
Enter a value. Press Enter to leave empty.
client_id>
```
Press **Enter** (leave blank for now, or follow the link to create your own)

### 3.5 OAuth Client Secret
```
OAuth Client Secret
Leave blank normally.
Enter a value. Press Enter to leave empty.
client_secret>
```
Press **Enter** (leave blank)

### 3.6 Scope
```
Scope that rclone should use when requesting access from drive.
Choose a number from below, or type in your own value.
 1 / Full access all files, excluding Application Data Folder.
   \ (drive)
 2 / Read-only access to file metadata and file contents.
   \ (drive.readonly)
...
scope> 1
```
Type: **1** (for full access) and press Enter

### 3.7 Root Folder ID
```
ID of the root folder
Leave blank normally.
Enter a value. Press Enter to leave empty.
root_folder_id>
```
Press **Enter** (leave blank to access entire Google Drive)

### 3.8 Service Account File
```
Service Account Credentials JSON file path
Leave blank normally.
Enter a value. Press Enter to leave empty.
service_account_file>
```
Press **Enter** (leave blank)

### 3.9 Advanced Config
```
Edit advanced config?
y) Yes
n) No (default)
y/n> n
```
Type: **n** and press Enter

### 3.10 Use Auto Config
```
Use auto config?
 * Say Y if not sure
 * Say N if you are working on a remote or headless machine

y) Yes (default)
n) No
y/n> n
```
Type: **n** (because NAS is headless/remote) and press Enter

### 3.11 Authorize on Another Machine

Since you chose "n" for auto config, you'll see instructions like this:

```
Option config_token.
For this to work, you will need rclone available on a machine that has
a web browser available.
For more help and alternate methods see: https://rclone.org/remote_setup/
Execute the following on the machine with the web browser (same rclone
version recommended):
	rclone authorize "drive" "eyJzY29wZSI6ImRyaXZlIn0"
Then paste the result.
Enter a value.
config_token>
```

**IMPORTANT STEPS:**

**Option A: Run command on your PC (if you have rclone installed there):**
1. **Copy the entire command** shown (e.g., `rclone authorize "drive" "eyJzY29wZSI6ImRyaXZlIn0"`)
2. **Open terminal on your PC/laptop** (must have rclone installed)
3. **Run the command** - it will open your browser automatically
4. **Log into your Google account** and grant permissions
5. **Copy the entire token output** from the terminal (starts with `{"access_token":...}`)
6. **Paste it back** into the NAS terminal at the `config_token>` prompt

**Option B: If you don't have rclone on your PC:**
1. Install rclone on your PC first:
   - Windows: Download from https://rclone.org/downloads/
   - Mac: `brew install rclone`
   - Linux: `sudo apt-get install rclone` or `curl https://rclone.org/install.sh | sudo bash`
2. Then follow Option A steps above

**Option C: Alternative manual method (if command doesn't work):**
If the command method fails, you might see a URL instead. In that case:
1. Copy the URL shown
2. Open it in any browser
3. Authorize the app
4. Copy the verification code back to the NAS

### 3.12 Configure as Team Drive
```
Configure this as a Shared Drive (Team Drive)?
y) Yes
n) No (default)
y/n> n
```
Type: **n** and press Enter (unless you're using a Shared Drive)

### 3.13 Confirm Configuration
```
Configuration complete.
Options:
- type: drive
- scope: drive
- token: {"access_token":"..."}
Keep this "gdrive" remote?
y) Yes this is OK (default)
e) Edit this remote
d) Delete this remote
y/e/d> y
```
Type: **y** and press Enter

### 3.14 Exit Config
```
Current remotes:

Name                 Type
====                 ====
gdrive               drive

e) Edit existing remote
n) New remote
d) Delete remote
r) Rename remote
c) Copy remote
s) Set configuration password
q) Quit config
e/n/d/r/c/s/q> q
```
Type: **q** and press Enter to quit

## Step 4: Test Your Connection

```bash
# List your Google Drive folders
rclone lsd gdrive:

# List all files in root
rclone ls gdrive:

# Test with a specific folder
rclone lsd gdrive:MyFolder
```

## Step 5: Update Your Script

Now edit `rclonetest.sh` and set:

```bash
RCLONE_REMOTE="gdrive:"              # For entire Google Drive
# OR
RCLONE_REMOTE="gdrive:MyFolder"      # For a specific folder
```

## Troubleshooting

### If you get "command not found" for rclone config:
```bash
# Check if rclone is installed
which rclone

# If not found, install it:
sudo apt-get install rclone
# OR download latest version:
curl https://rclone.org/install.sh | sudo bash
```

### If authorization fails:
- Make sure you copied the ENTIRE URL (it's very long)
- Use incognito/private browsing mode
- Try a different browser
- Check that you're logged into the correct Google account

### If you see "rate limit" errors:
- Consider creating your own Google API Client ID (see: https://rclone.org/drive/#making-your-own-client-id)
- This gives you better performance and higher quotas

## Next Steps

After setup, you can use these commands:

```bash
# Check remote name
rclone listremotes

# View remote contents
rclone tree gdrive:

# Test sync (dry-run)
rclone sync gdrive: /path/to/local --dry-run -v
```

Now you're ready to use the sync script!
