# Create a single default user
user = User.find_or_create_by(phone: '0987654321') do |u|
  u.name = 'Admin User'
  u.password = BCrypt::Password.create('0987654321')
end

if user.persisted?
  puts "   Default user created successfully!"
  puts "   Phone: 0987654321"
  puts "   Password: 0987654321"
else
  puts "Failed to create user: #{user.errors.full_messages.join(', ')}"
end

# Create sample categories
categories_data = [
  { name: 'Appetizers' },
  { name: 'Main Courses' },
  { name: 'Desserts' },
  { name: 'Beverages' }
]

categories_data.each do |cat_data|
  category = Category.find_or_create_by(name: cat_data[:name])
  puts "Category '#{category.name}' created/found"
end

# Create sample menu items
menu_items_data = [
  # Appetizers
  {
    name: 'Crispy Spring Rolls',
    ingredients: 'Fresh vegetables, rice paper, sweet chili sauce',
    price: 45.00,
    image: 'https://images.unsplash.com/photo-1544025162-d76694265947?w=400',
    available: true,
    out_of_stock: false,
    badge: 'Popular',
    category_name: 'Appetizers'
  },
  {
    name: 'Garlic Bread',
    ingredients: 'Fresh bread, garlic butter, herbs',
    price: 35.00,
    image: 'https://images.unsplash.com/photo-1573140247632-f8fd74997d5c?w=400',
    available: true,
    out_of_stock: false,
    badge: 'New',
    category_name: 'Appetizers'
  },
  
  # Main Courses
  {
    name: 'Grilled Chicken Breast',
    ingredients: 'Tender chicken breast, herbs, vegetables',
    price: 120.00,
    image: 'https://images.unsplash.com/photo-1532550907401-a500c9a57435?w=400',
    available: true,
    out_of_stock: false,
    badge: 'Recommended',
    category_name: 'Main Courses'
  },
  {
    name: 'Beef Steak',
    ingredients: 'Premium beef, seasoning, side vegetables',
    price: 180.00,
    image: 'https://images.unsplash.com/photo-1546833999-b9f581a1996d?w=400',
    available: true,
    out_of_stock: false,
    badge: 'Popular',
    category_name: 'Main Courses'
  },
  {
    name: 'Vegetarian Pasta',
    ingredients: 'Fresh pasta, vegetables, tomato sauce',
    price: 85.00,
    image: 'https://images.unsplash.com/photo-1621996346565-e3dbc353d2e5?w=400',
    available: true,
    out_of_stock: false,
    badge: 'Vegan',
    category_name: 'Main Courses'
  },
  
  # Desserts
  {
    name: 'Chocolate Cake',
    ingredients: 'Rich chocolate, cream, berries',
    price: 65.00,
    image: 'https://images.unsplash.com/photo-1578985545062-69928b1d9587?w=400',
    available: true,
    out_of_stock: false,
    badge: 'Popular',
    category_name: 'Desserts'
  },
  {
    name: 'Ice Cream Sundae',
    ingredients: 'Vanilla ice cream, chocolate sauce, nuts',
    price: 45.00,
    image: 'https://images.unsplash.com/photo-1563805042-7684c019e1cb?w=400',
    available: true,
    out_of_stock: false,
    badge: '',
    category_name: 'Desserts'
  },
  
  # Beverages
  {
    name: 'Fresh Orange Juice',
    ingredients: 'Freshly squeezed oranges',
    price: 25.00,
    image: 'https://images.unsplash.com/photo-1621506289937-a8e4df240d0b?w=400',
    available: true,
    out_of_stock: false,
    badge: 'New',
    category_name: 'Beverages'
  },
  {
    name: 'Ethiopian Coffee',
    ingredients: 'Premium Ethiopian coffee beans',
    price: 30.00,
    image: 'https://images.unsplash.com/photo-1495474472287-4d71bcdd2085?w=400',
    available: true,
    out_of_stock: false,
    badge: 'Recommended',
    category_name: 'Beverages'
  }
]

menu_items_data.each do |item_data|
  category = Category.find_by(name: item_data[:category_name])
  next unless category
  
  menu = Menu.find_or_create_by(name: item_data[:name], category: category) do |m|
    m.ingredients = item_data[:ingredients]
    m.price = item_data[:price]
    m.image = item_data[:image]
    m.available = item_data[:available]
    m.out_of_stock = item_data[:out_of_stock]
    m.badge = item_data[:badge]
  end
  
  puts "Menu item '#{menu.name}' created/found in category '#{category.name}'"
end

puts "Sample data seeded successfully!"