import express from 'express';
const router = express.Router();
const Product = require('../models/Product');

// GET /products?limit=xx&skip=xx
router.get('/', async (req, res) => {
  try {
    const limit = parseInt(req.query.limit) || 30;
    const skip = parseInt(req.query.skip) || 0;

    const products = await Product.find().skip(skip).limit(limit);
    const total = await Product.countDocuments();

    res.json({
      products,
      total,
      skip,
      limit
    });
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
});

// GET /products/category-list
router.get('/category-list', async (req, res) => {
  try {
    const categories = await Product.distinct('category');
    res.json(categories);
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
});

// GET /products/category/:category
router.get('/category/:category', async (req, res) => {
  try {
    const category = req.params.category;
    const limit = parseInt(req.query.limit) || 30;
    const skip = parseInt(req.query.skip) || 0;

    const products = await Product.find({ category }).skip(skip).limit(limit);
    const total = await Product.countDocuments({ category });

    res.json({
      products,
      total,
      skip,
      limit
    });
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
});

// GET /products/search?q=:query
router.get('/search', async (req, res) => {
  try {
    const query = req.query.q || '';
    const limit = parseInt(req.query.limit) || 30;
    const skip = parseInt(req.query.skip) || 0;

    // Use regular expression for case-insensitive search on title or description
    const regex = new RegExp(query, 'i');
    const filter = {
      $or: [
        { title: regex },
        { description: regex },
        { brand: regex }
      ]
    };

    const products = await Product.find(filter).skip(skip).limit(limit);
    const total = await Product.countDocuments(filter);

    res.json({
      products,
      total,
      skip,
      limit
    });
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
});

module.exports = router;
