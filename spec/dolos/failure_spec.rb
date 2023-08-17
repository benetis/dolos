# frozen_string_literal: true

RSpec.describe Dolos::Result do
  include Dolos

  describe 'failure' do
    it 'returns a failure' do
      hello = c("Hello") >> c(" ") >> c("Good errors")

      result = hello.run("Hello Goodbye")
      expect(result.success?).to be false

      error_msg = <<~ERROR_MSG.chomp
      Failure: Expected "Good errors" but got "Goodby"
      Hello Goodbye
            ^
      Error Position: 6, Last Success Position: 5
      ERROR_MSG

      expect(result.inspect).to eq(error_msg)
    end

    it 'returns a failure with choice' do
      hello = c("Good errors") >> c(" ") >> (c("or not") | c("or yes"))

      result = hello.run("Good errors or maybe")
      expect(result.success?).to be false

      error_msg = <<~ERROR_MSG.chomp
      Failure: Expected "or yes" but got "or maybe"
      od errors or maybe
                ^
      Error Position: 12, Last Success Position: 11
      ERROR_MSG

      expect(result.inspect).to eq(error_msg)
    end

    it 'returns failure with repeat' do
      hello = (c("Good errors") >> c(" ").opt).rep(6)

      result = hello.run("Good errors Good errors Good errors Good errors")
      expect(result.success?).to be false

      error_msg = <<~ERROR_MSG.chomp
      Failure: Expected parser to match at least 6 times but matched only 4 times
      ood errors
                ^
      Error Position: 47, Last Success Position: 0
      ERROR_MSG

      expect(result.inspect).to eq(error_msg)
    end
  end
end
