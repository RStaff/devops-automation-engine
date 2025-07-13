require("dotenv").config();
const express = require("express"), stripe = require("stripe")(process.env.STRIPE_SECRET_KEY);
const app = express();
app.use(express.json());
app.use(express.static("public"));
app.post("/create-checkout-session", async (req,res)=>{
  try {
    const session = await stripe.checkout.sessions.create({
      payment_method_types:["card"],mode:"payment",
      line_items:[{price_data:{currency:"usd",product_data:{name:"Your Product Name"},unit_amount:5000},quantity:1}],
      success_url:`\${req.headers.origin}/success.html`,
      cancel_url:`\${req.headers.origin}/cancel.html`,
    });
    res.json({url:session.url});
  } catch(e){ res.status(500).json({error:e.message}); }
});
app.listen(4242,()=>console.log("Server on http://localhost:4242"));
