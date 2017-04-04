ruleset manage_fleet {
  meta {
    name "Manage Fleet"
    author "Ben Jacobson"
    logging on
    shares __testing, create_vehicle
  }

  global {
    __testing = {
      "events": [
        {
          "domain": "car",
          "type": "new_vehicle"
        },
        {
          "domain": "reset",
          "type": "sections"
        }
      ]
    }

    installRule = function(other_eci, rule_name) {
      event:send({
        "eci": other_eci,
        "eid": "install-ruleset",
        "domain": "pico",
        "type": "new_ruleset",
        "attrs": {
          "rid": rule_name
        } 
      })
    }

    subscribe = function(my_eci, subscriber_eci) {
      event:send({
        "eci": my_eci,
        "eid": "subscription",
        "domain": "wrangler",
        "type": "subscription",
        "attrs": {
          "name": "vehicle",
          "name_space": "fleet",
          "my_role": "fleet",
          "subscriber_role": "vehicle",
          "channel_type": "subscription",
          "subscriber_eci": subscriber_eci
        }
      })
    }
  }

  rule reset_sections {
    select when reset sections
    send_directive("sections reset")
    always {
      ent:sections := []
    }
  }

  rule create_vehicle {
    select when car new_vehicle
    pre {
      name = event:attr("name")
      exists = ent:sections >< name
      eci = meta:eci
    }
    if name.isnull() || exists then
      send_directive("section_not_created")
        with name = name
    fired {
    } else {
      ent:sections := ent:sections.defaultsTo([]).union([name]);
      raise pico event "new_child_request"
        attributes { "dname": name, "color": "#FF69B4" }
    }
  }


  rule pico_child_initialized {
    select when pico child_initialized
    pre {
      new_child_eci = event:attrs(){["new_child", "eci"]}
    }
    installRule(new_child_eci, "Subscriptions")
    installRule(new_child_eci, "trip_store")
    installRule(new_child_eci, "track_trips")
    subscribe(meta:eci, new_child_eci)
    always {
      ent:child_attrs := event:attrs()
    }
  }
}