ruleset trip_store {
  meta {
    name "Track Trips"
    author "Ben Jacobson"
    logging on
    shares __testing
  }

  global {
    __testing = {
      "events": [{
        "domain": "init",
        "type": "ent"
      }]
    }
    init_trips = {}
  }

  rule init_ent {
    select when init ent
    always {
      ent:trips := init_trips
    }
  }

  rule collect_trips {
    select when explicit trip_processed
    always {
      ent:trips{[time:now()]} := event:attr("mileage").defaultsTo(0).as("Number")
    }
  }

  rule collect_long_trips {
    select when explicit found_long_trip
    send_directive("long_trip") with
      message = "found long trip"
  }
}