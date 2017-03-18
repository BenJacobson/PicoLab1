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
        attributes event:attrs();
      raise explicit event "found_long_trip"
    }
  }

  rule find_long_trips {
    select when explicit trip_processed
    pre {
      mileage = event:attr("mileage")
    }
    fired {
      last if mileage < long_trip
    }
  }

  rule count_long_trips {
    select when explicit found_long_trip
    send_directive("long trips") with
      count = 1
  }
}