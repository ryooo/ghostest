module Llm
  module Functions
    class Base
      def function_name
        nil
      end

      def stop_llm_call?
        false
      end
    end
  end
end
