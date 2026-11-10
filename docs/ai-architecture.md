# AI preparation (Mission 001)

The assistant UI is an explicit “Coming in Mission 002” placeholder. A future implementation should provide:

```ruby
module Ai
  class Provider
    def generate(_messages:, _tools:); raise NotImplementedError; end
  end

  class ProposedAction
    attr_reader :tool_name, :arguments, :reason
    def initialize(tool_name:, arguments:, reason:); @tool_name, @arguments, @reason = tool_name, arguments, reason; end
  end
end
```

Tool registry entries must declare authorization, input schema, and safe output shape. Reads should be organization-scoped. Writes should produce a proposed action, require human approval, re-check authorization, execute through a service object, and emit an audit event. Background jobs should carry only an action ID and resolve current state at execution time.
