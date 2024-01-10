import { v2 as cloudinary } from "cloudinary";
import fs from "fs";

cloudinary.config({
  cloud_name: process.env.CLOUDINARY_NAME,
  api_key: process.env.CLOUDINARY_API_KEY,
  api_secret: process.env.CLOUDINARY_API_KEY_SECRET,
});

const uploadFiledOnCloudinary = async function (localFilePath) {
  try {
    //check for file
    if (!localFilePath) {
      throw new Error("Local file path is missing");
    }
    //upload to cloudinay
    const response = await cloudinary.uploader.upload(localFilePath, {
      resource_type: "auto",
    });
    //get the url from response
    console.log("File Successfully uploaded on Cloudinary", response.url);
    console.log("Cloudiany full response", response);

    //unlink the file after successfull upload from local path with fs (file system)
    fs.unlinkSync(localFilePath.trim());

    //return respone
    return response;
  } catch (error) {
    //unlink the file after failure form locally with file systemm (fs)
    fs.unlinkSync(localFilePath.trim());
    console.log("Something went wrogn while uplaoding files on cloudinary");
    return null;
  }
};

export { uploadFiledOnCloudinary };
