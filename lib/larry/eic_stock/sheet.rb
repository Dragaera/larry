module Larry
  module EICStock
    class Sheet
      def initialize
        @session     = GoogleDrive::Session.from_service_account_key(Config::EICStock::SESSION_CONFIGURATION_FILE)
        @spreadsheet = @session.spreadsheet_by_key(Config::EICStock::SPREADSHEET_KEY)
        @stock_sheet = @spreadsheet.worksheet_by_title('Stock')
        raise RuntimeError, "No worksheet with title 'Stock' found" unless @stock_sheet
      end

      def whales
        whale_rows = []
        rows = @stock_sheet.rows.dup

        header = rows.shift
        while !rows.empty? && rows.first[0] != 'Total'
          whale_rows << rows.shift
        end

        whale_rows.map { |row| row.first }
      end

      def reload
        @stock_sheet.reload
      end
    end
  end
end
