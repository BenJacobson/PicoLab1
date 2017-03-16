ruleset {
	meta {
		name "Hello World"
    	author "Ben Jacobson"
    	logging on
    	shares ___
	}

	global {

	}

	rule {
		select when echo hello
		send_directive("say") with
			something = "Hello World"
	}

	rule {
		select when echo message
		pre{
			input = event:attr("input")
		}
		send_directive("say") with
			something = input
	}
}