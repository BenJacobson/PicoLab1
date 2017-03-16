ruleset echo_service {
  meta {
    name "Hello World"
    author "Ben Jacobson"
    logging on
    shares hello, message
  }

  global {

  }

  rule hello {
    select when echo hello
    send_directive("say") with
    something = "Hello World"
  }

  rule message {
    select when echo message
    pre {
      input = event:attr("input")
    }
    send_directive("say") with
    something = input
  }
}