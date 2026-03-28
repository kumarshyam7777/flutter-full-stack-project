import mongoose from 'mongoose';
import Product from './models/Product.js';

const MONGO_URI = process.env.MONGO_URI || 'mongodb://127.0.0.1:27017/flutter_api_db';

const seedDatabase = async () => {
  try {
    // 1. Connect to MongoDB
    await mongoose.connect(MONGO_URI);
    console.log(`Connected to MongoDB: ${MONGO_URI}`);

    // 2. Clear existing products to prevent duplicates on multiple runs
    await Product.deleteMany({});
    console.log('Cleared existing products in DB.');

    // 3. Fetch products from dummyjson.com API
    const res = await fetch('https://dummyjson.com/products?limit=50');
    const data = await res.json();
    const products = data.products;

    if (!products || products.length === 0) {
      console.log('No products found from dummyjson.');
      process.exit(0);
    }

    // 4. Map the data if needed (it matches our schema closely)
    const formattedProducts = products.map(p => ({
      id: p.id,
      title: p.title,
      description: p.description,
      price: p.price,
      discountPercentage: p.discountPercentage,
      rating: p.rating,
      stock: p.stock,
      brand: p.brand || 'Unknown',
      category: p.category,
      thumbnail: p.thumbnail,
      images: p.images || []
    }));

    // 5. Insert into MongoDB
    await Product.insertMany(formattedProducts);
    console.log(`Successfully seeded ${formattedProducts.length} products to database.`);

    // 6. Close connection
    mongoose.connection.close();
    console.log('Database connection closed.');
    process.exit(0);
  } catch (err) {
    console.error('Error seeding database:', err);
    mongoose.connection.close();
    process.exit(1);
  }
};

seedDatabase();
