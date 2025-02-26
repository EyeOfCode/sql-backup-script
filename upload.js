const { initializeApp } = require("firebase/app");
const {
  getStorage,
  ref,
  uploadBytes,
  deleteObject,
  listAll,
} = require("firebase/storage");
const path = require("path");
const fs = require("fs");
require("dotenv").config();

const firebaseConfig = {
  apiKey: process.env.FIREBASE_API_KEY,
  authDomain: process.env.FIREBASE_AUTH_DOMAIN,
  projectId: process.env.FIREBASE_PROJECT_ID,
  storageBucket: process.env.FIREBASE_STORAGE_BUCKET,
  messagingSenderId: process.env.FIREBASE_MESSAGING_SENDER_ID,
  appId: process.env.FIREBASE_APP_ID,
  measurementId: process.env.FIREBASE_MEASUREMENT_ID,
};

const app = initializeApp(firebaseConfig);
const storage = getStorage(app);
const dirPath = path.join(__dirname, "backups_db");

async function deleteOldFilesIfNecessary() {
  const listRef = ref(storage, `${process.env.BACKUP_PATH}/`);

  try {
    console.log(
      `Deleting old files on firebase on dir ${process.env.BACKUP_PATH}/...`
    );
    const fileList = await listAll(listRef);
    if (!fileList || !fileList.items || fileList.items.length === 0) {
      console.error("No files available for deletion.");
      return;
    }

    const maxFiles = Number(process.env.MAX_FILES) || 3;

    if (fileList.items.length >= maxFiles) {
      fileList.items.sort((a, b) => a.name.localeCompare(b.name));
      const oldestFile = fileList.items[0];
      await deleteObject(oldestFile);
      console.log(`Old file ${oldestFile.name} deleted.`);
    }
  } catch (err) {
    console.error("Error deleting old files:", err);
  }
}

fs.readdir(dirPath, (err, files) => {
  if (err) {
    console.error("Error reading directory:", err);
    return;
  }

  deleteOldFilesIfNecessary().then(() => {
    if (files.length === 0) {
      console.log("No files found in the directory.");
      return;
    }
    files.forEach((file) => {
      const filePath = path.join(dirPath, file);
      const destFileName = `${process.env.BACKUP_PATH}/${file}`;
      const fileRef = ref(storage, destFileName);

      if (file !== ".gitignore") {
        fs.readFile(filePath, (err, data) => {
          if (err) {
            console.error(`Error reading file ${file}:`, err);
            return;
          }

          uploadBytes(fileRef, data)
            .then(() => {
              console.log(
                `File ${file} uploaded successfully to Firebase Storage`
              );
            })
            .catch((err) => {
              console.error(
                `Error uploading file ${file} to Firebase Storage:`,
                err
              );
            });
        });
      }
    });
  });
});
