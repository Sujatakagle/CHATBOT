// const User=require('./post_model');
  

// exports.createuser = async (req, resp) => {
//     try {
//       // Extract name and email from request body
//       const { name, email } = req.body;
  
//       // Validate that both fields are provided
//       if (!name || !email) {
//         return resp.status(400).json({ error: 'Name and email are required' });
//       }
  
//       // Create a new user instance
//       const user = new User({ name, email });
//       await user.save();
  
//       // Send success response with message
//       resp.status(201).json({
//         message: 'User added successfully',
//         user: user,
//       });
//     } catch (error) {
//       resp.status(500).json({ error: error.message });
//     }
//   };
  

// exports.getuser=async(req,resp)=>{
//   try{
//     const users=await User.find();
//     resp.status(200).json({message:'added successfully',users});
//   }catch(error){
//     resp.status(400).json({error:error.message});
//   }
// }

// exports.updateuser=async(req,resp)=>{
//   try{
//     const users=await User.findOneAndUpdate(req.body);
//     resp.status(200).json(users);
//   }catch(error){
//     resp.status(400).json({error:error.message});
//   }
// }
// exports.deleteUser = async (req, resp) => {
//   try {
//     const user = await User.findByIdAndDelete(req.params.id);

//     if (!user) {
//       return resp.status(404).json({ error: 'User not found' });
//     }

//     resp.status(200).json({ message: 'User deleted successfully' });
//   } catch (error) {
//     resp.status(500).json({ error: error.message });
//   }
// };