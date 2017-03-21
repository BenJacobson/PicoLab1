ruleset track_trips_2 {
  meta {
    name "Track Trips"
    author "Ben Jacobson"
    logging on
    shares process_trip
  }

  global {
    long_trip = 10
  }

  rule process_trip {
    select when car new_trip
    pre {
      mileage = event:attr("mileage")
    }
    send_directive("trip") with
      trip_length = mileage
    fired {
      raise explicit event "trip_processed"
        attributes event:attrs()
    }
  }

  rule find_long_trips {
    select when explicit trip_processed
    pre {
      mileage = event:attr("mileage").defaultsTo(0).as("Number")
      time = time:now()
    }
    fired {
      raise explicit event "found_long_trip"
        attributes event:attrs().put({"time":time:now()})
        if (mileage >= long_trip)
    }
  }
}