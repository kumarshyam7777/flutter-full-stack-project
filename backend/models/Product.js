const mongoose = require('mongoose');

const productSchema = new mongoose.Schema({
  id: { 
    type: Number, 
    required: true, 
    unique: true 
  },
  title: { 
    type: String, 
    required: true 
  },
  description: { 
    type: String, 
    default: '' 
  },
  price: { 
    type: Number, 
    required: true 
  },
  discountPercentage: { 
    type: Number, 
    default: 0 
  },
  rating: { 
    type: Number, 
    default: 0 
  },
  stock: { 
    type: Number, 
    default: 0 
  },
  brand: { 
    type: String, 
    default: 'Unknown' 
  },
  category: { 
    type: String, 
    default: '' 
  },
  thumbnail: { 
    type: String, 
    default: '' 
  },
  images: [{ 
    type: String 
  }]
}, {
  timestamps: true
});

module.exports = mongoose.model('Product', productSchema);
