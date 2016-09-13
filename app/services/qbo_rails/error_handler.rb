class QboRails
  module ErrorHandler
    def handle_error_name_entity_already_exists(exception)
      puts "YOYOYOYO WHAT IT IS?"
      if exception.message =~ /Duplicate Name Exists Error.*Another (customer|vendor|employee)/m
        display_name = Nokogiri::XML(exception.request_xml).at('DisplayName').content
        result = @base.find_by_display_name(display_name)
        if result.entries.size == 1
          @record.update_column(:qbo_id, result.entries.first.id)
          @only_run_once = true
          @record.reload
          create_or_update(@record, @qb_record)
          true
        else
          false
        end
      else
        false
      end
    end
  end
end
