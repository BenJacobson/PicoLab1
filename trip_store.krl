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
    pre {
      mileage = event:attr("mileage").defaultsTo(0)
    }
    send_directive("test") with
      trip_lengths = ent:trips
    always {
      ent:trips{[time:now()]} := mileage
    }
  }
}