import { User } from "../models/user.model.js";
import { ApiError } from "../utils/ApiError.js";
import { ApiResponse } from "../utils/ApiResponse.js";
import { asyncHandler } from "../utils/asyncHandler.js";
import { UploadFileOnCloudinary } from "../utils/cloudinary.js";

const registerUser = asyncHandler(async (req, res) => {
  //Get the details from the user --> req.body
  //validate the user
  //check user is already regitered or not
  //check for images
  //upload images to cloudinary
  //create user object
  //return response
  const { username, fullname, email, password } = req.body;
  if (
    [username, fullname, email, password].some(
      (fields) => fields?.trim() === ""
    )
  ) {
    throw new ApiError(400, "All fields are required");
  }
  //
  const existingUser = await User.findOne({ $or: [{ username }, { email }] });
  if (existingUser) {
    throw new ApiError(400, "username or email is already registered");
  }

  const avatarLocalPath = req.files?.avatar[0]?.path; //req/files for multiple (from multer)
  // const coverImageLocalPath = req.files?.coverImage[0]?.path;
  let coverImageLocalPath;
  if (
    req.files &&
    Array.isArray(req.files.coverImage) &&
    req.files.coverImage.length > 0
  ) {
    coverImageLocalPath = req.files.coverImage[0].path;
  }
  /* let coverImageLocalPath;
  if (req.files && req.files.coveImage.length > 0) {
    coverImageLocalPath = req.files.coveImage[0].path;
  }  */

  const avatar = await UploadFileOnCloudinary(avatarLocalPath);
  const coverImage = await UploadFileOnCloudinary(coverImageLocalPath);

  if (!avatar) {
    throw new ApiError(400, "Avatar is required");
  }

  const user = await User.create({
    username,
    email,
    fullname,
    password,
    avatar: avatar.url,
    coverImage: coverImage?.url || "",
  });

  const createdUser = await User.findById(user._id).select(
    "-password -refreshToken"
  );

  return res
    .status(200)
    .json(new ApiResponse(200, createdUser, "User registered successfully"));
});

const generateAccessAndRefreshToken = async function (userId) {
  try {
    const user = await User.findById(userId);
    const accessToken = user.generateAccessToken();
    const refreshToken = user.generateRefreshToken();

    user.refreshToken = refreshToken;
    await user.save({ validateBeforeSave: false });
    return { accessToken, refreshToken };
  } catch (error) {
    throw new ApiError(
      500,
      "Something went wrong while generating access and refresh token"
    );
  }
};

const loginUser = asyncHandler(async (req, res) => {
  //get the data form user
  //validate the data
  //check user is registered or not
  //check password
  //generate access and refresh token
  //set options to send in cookies
  //send response

  const { username, email, password } = req.body;
  if (!(username || email)) {
    throw new ApiError(400, "Username or email required");
  }
  //
  const user = await User.findOne({ $or: [{ username }, { email }] });
  if (!user) {
    throw new ApiError(409, "username or email is not registered");
  }
  //
  const isPasswordMatch = await user.isPasswordCorrect(password);
  console.log("IsPasswordMatch", isPasswordMatch);

  if (!isPasswordMatch) {
    throw new ApiError(400, "Password Invalid");
  }
  //generate token
  const { accessToken, refreshToken } = await generateAccessAndRefreshToken(
    user._id
  );

  const loggedInUser = await User.findById(user._id).select(
    "-password -refreshToken"
  );
  //create options
  const options = {
    httpOnly: true,
    secure: true,
  };
  //return response
  return res
    .status(200)
    .cookie("accessToken", accessToken, options)
    .cookie("refreshToken", refreshToken, options) //app.use(cookieParser())
    .json(
      new ApiResponse(
        200,
        { user: loggedInUser, accessToken, refreshToken },
        "User logged in successfully"
      )
    );
});

const logoutUser = asyncHandler(async (req, res) => {
  //only logged in user can logout so for that I need to verify user by accesstoken from cookies

  await User.findByIdAndUpdate(
    req.user?._id,
    {
      $unset: {
        refreshToken: 1,
      }, //this removes the refresh token field
    },
    {
      new: true,
    }
  );

  const options = {
    httpOnly: true,
    secure: true,
  };

  //send the response and clear the cookies
  return res
    .status(200)
    .clearCookie("accessToken", options)
    .clearCookie("refreshToken", options)
    .json(new ApiResponse(200, {}, "User logged out successfully"));
});

const getCurrentUser = asyncHandler(async (req, res) => {
  console.log(req.user);
  return res
    .status(200)
    .json(new ApiResponse(200, req.user, "Current User Fetched Successfully"));
});

const updateAccountDetails = asyncHandler(async (req, res) => {
  try {
    const { username, email, fullname } = req.body;
    const updateFields = {
      username,
      email,
      fullname,
    };
    //avatar check
    if (
      req.files &&
      Array.isArray(req.files?.avatar) &&
      req.files?.avatar.length > 0
    ) {
      const avatarLocalPath = req.files.avatar[0].path;
      const avatar = await UploadFileOnCloudinary(avatarLocalPath);
      updateFields.avatar = avatar.url || avatar;
    }
    //coverImage check
    if (
      req.files &&
      Array.isArray(req.files?.coverImage) &&
      req.files.coverImage.length > 0
    ) {
      const coverImageLocalPath = req.files.coverImage[0].path;
      const coverImage = await UploadFileOnCloudinary(coverImageLocalPath);
      updateFields.coverImage = coverImage.url || coverImage;
    }
    //update in the data
    const user = await User.findByIdAndUpdate(
      req.user._id,
      {
        $set: updateFields,
      },
      {
        new: true,
      }
    ).select("-password -refreshToken");

    //return response
    return res
      .status(200)
      .json(new ApiResponse(200, user, "User details updated successfully"));
  } catch (error) {
    throw new ApiError(400, "Error while updating user details");
  }
});

const changeCurrentPassword = asyncHandler(async (req, res) => {
  const { oldPassword, newPassword, confirmPassword } = req.body;

  if (!(newPassword == confirmPassword)) {
    throw new ApiError(400, "New password and Confirm Password does not match");
  }
  //get the user
  const user = await User.findById(req.user?._id);

  if (!user) {
    throw new ApiError(401, "User not found");
  }
  //check the old password
  const isPasswordMatch = await user.isPasswordCorrect(oldPassword);
  console.log("Old Password Matched:", isPasswordMatch);
  if (!isPasswordMatch) {
    throw new ApiError(400, "Invalid Old Password");
  }
  //then we can set new password from user  (req.user = user(auth middleware))
  user.password = newPassword;
  // Save the updated user to MongoDB
  await user.save({ validateBeforeSave: false });
  return res
    .status(200)
    .json(new ApiResponse(200, {}, "Password Changed Succssfully"));
});

export {
  changeCurrentPassword,
  getCurrentUser,
  loginUser,
  logoutUser,
  registerUser,
  updateAccountDetails,
};
