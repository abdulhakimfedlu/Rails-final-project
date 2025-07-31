require 'cloudinary'

class ImageUploadService
  def self.upload(file)
    return nil unless file.present? && file.respond_to?(:tempfile)
    
    begin
      # Configure Cloudinary
      Cloudinary.config do |config|
        config.cloud_name = ENV['CLOUDINARY_CLOUD_NAME']
        config.api_key = ENV['CLOUDINARY_API_KEY']
        config.api_secret = ENV['CLOUDINARY_API_SECRET']
      end

      # Upload to Cloudinary
      result = Cloudinary::Uploader.upload(file.tempfile.path, {
        folder: 'restaurant_app',
        resource_type: 'auto',
        quality: 'auto:good',
        fetch_format: 'auto'
      })
      
      result['secure_url']
    rescue => e
      Rails.logger.error "Image upload failed: #{e.message}"
      nil
    end
  end
end