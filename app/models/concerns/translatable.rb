module Translatable
	extend ActiveSupport::Concern

	included do
    	has_many "#{self.class_name.underscore}_translations".to_sym, inverse_of: "#{self.class_name.underscore}".to_sym, autosave: true

		attr_accessor :_translations
	end

	class_methods do
		def translate_attrs(*attributes)
			attributes.each do |att|
				define_method "#{att.to_s}" do
					
					Rails.logger.debug("row: #{id} translations: #{translations.size} langs: #{translations.to_json}\n\n")

					if translations[I18n.locale].nil? && translations[:es]
						translations[:es][att]
					elsif translations[I18n.locale]
						translations[I18n.locale][att]
					else
						nil
					end
				end

				define_method "#{att.to_s}=" do |val|
					changed = false
					send("#{self.class.name.underscore}_translations").each do |t|
						if t.locale == I18n.locale.to_s
							t.attributes = {att => val}
							changed = true
						end
					end
					unless changed
						send("#{self.class.name.underscore}_translations").build(att => val, locale: I18n.locale)
					end
				end
			end

			define_method "translations" do
				return _translations unless _translations.nil?
				_translations = {}
				unless send("#{self.class.name.underscore}_translations").empty?
					send("#{self.class.name.underscore}_translations").each do |translation|
						_translations[translation.locale.to_sym] = Hash[attributes.map {|attr_sym| [attr_sym,translation[attr_sym.to_s]]}]
					end
				end
				_translations
			end

		end
	end


end