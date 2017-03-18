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
    init_trips = [0]
    add_trip = function(mileage) {
      ent:trips.append(mileage);
    }
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
      mileage = event:attr("mileage")
    }
    ent:trips.append(mileage)
    send_directive("test") with
      trip_lengths = ent:trips
  }
}