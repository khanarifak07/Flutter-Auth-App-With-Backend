import { v2 as cloudinary } from "cloudinary";
import fs from "fs";

cloudinary.config({
  cloud_name: process.env.CLOUDINARY_NAME,
  api_key: process.env.CLOUDINARY_API_KEY,
  api_secret: process.env.CLOUDINARY_API_KEY_SECRET,
});

const UploadFileOnCloudinary = async (localFilePath) => {
  try {
    if (!localFilePath) return null;
    //upload to cloudinary
    const response = await cloudinary.uploader.upload(localFilePath, {
      resource_type: "auto",
    });
    //
    console.log("File Successfully Uploded on Cloudinary", response.url);
    //unlink file after successfull upload
    fs.unlinkSync(localFilePath);
    //return response
    return response;
  } catch (error) {
    //unlink file after failure
    fs.unlinkSync(localFilePath);
    return null;
  }
};

export { UploadFileOnCloudinary };
