ruleset trip_store {
  meta {
    name "Track Trips"
    author "Ben Jacobson"
    logging on
    provides trips, long_trips, short_trips
    shares __testing, trips, long_trips, short_trips
  }

  global {
    __testing = {
      "events": [{
        "domain": "car",
        "type": "trip_reset"
      }]
    }

    init_trips = []
    init_long_trips = []

    trips = function() {
      ent:trips
    }
    long_trips = function() {
      ent:long_trips
    }
    short_trips = function() {
      ent:trips.filter(function(k, v) {v[0] < 10})
    }
  }

  rule clear_trips {
    select when car trip_reset
    always {
      ent:trips := init_trips;
      ent:long_trips := init_long_trips
    }
  }

  rule collect_trips {
    select when explicit trip_processed
    pre {
      mileage = event:attr("mileage")
      time = event:attr("time")
    }
    always {
      ent:trips := ent:trips.append([[mileage, time]])
    }
  }

  rule collect_long_trips {
    select when explicit found_long_trip
    pre {
      mileage = event:attr("mileage")
      time = event:attr("time")
    }
    always {
      ent:long_trips := ent:long_trips.append([[mileage, time]])
    }
  }
}