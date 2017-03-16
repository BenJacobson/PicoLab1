ruleset hello_world {
  meta {
    name "Hello World"
    author "Phil Windley"
    logging on
    shares hello
  }
  
  global {
    hello = function(obj) {
      msg = "Hello " + obj;
      msg
    }
  }
  
  rule hello_world {
    select when echo hello
    send_directive("say") with
      something = "Hello World"
  }
  
}