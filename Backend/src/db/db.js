import mongoose from "mongoose";
import { DB_NAME } from "../constants.js";

const dbConnect = async function () {
  try {
    const connectionInstance = await mongoose.connect(
      `${process.env.MONGO_URI}/${DB_NAME}`
    );
    console.log(
      `Successfully Connected to MONGO DB Host : ${connectionInstance.connection.host}`
    );
  } catch (error) {
    console.log("Error while connecting to MONGO DB", error);
    process.exit(1); //1 is use for failure
  }
};

export default dbConnect;
