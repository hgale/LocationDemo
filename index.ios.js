import React, { Component } from 'react'
import { NativeModules, NativeEventEmitter } from 'react-native'

import {
  AppRegistry,
  StyleSheet,
  Text,
  View
} from 'react-native'

// Poll location every 3 seconds
const LOCATION_POLL_FREQUENCY = 3 * 1000
const URL = 'http://localhost:8080'

export default class LocationDemo extends Component {
  constructor (props) {
    super(props)
    this.state = {
      pollLocation: null,
      lastPollTime: null
    }
    this.updateTime = this.updateTime.bind(this)
  }

  componentDidMount () {
    const locationManager = NativeModules.LocationManager
    locationManager.startPostingLocationTo(URL, LOCATION_POLL_FREQUENCY)

    const locationManagerEmitter = new NativeEventEmitter(locationManager)
    const pollLocation = locationManagerEmitter.addListener(
      'LocationUpdated',
      (location) => {
        let date = new Date(location.time)
        this.updateTime(date)
      }
    )
    this.setState({
      pollLocation: pollLocation
    })
  }

  componentWillUnmount () {
    NativeModules.LocationManager.stopPostingLocation()
    if (this.state.pollLocation) {
      this.state.pollLocation.remove()
    }
  }

  render() {
    let lastPoll = ''
    if (this.state.lastPollTime) {
       lastPoll = this.state.lastPollTime.toTimeString()
    }
    return (
      <View style={styles.container}>
        <Text style={styles.welcome}>
          Location Polling Demo
        </Text>
        <Text style={styles.welcome}> {lastPoll} </Text>
      </View>
    )
  }

  updateTime (date) {
    this.setState({ lastPollTime: date })
  }
}

const styles = StyleSheet.create({
  container: {
    flex: 1,
    justifyContent: 'center',
    alignItems: 'center',
    backgroundColor: '#F5FCFF',
  },
  welcome: {
    fontSize: 20,
    textAlign: 'center',
    margin: 10,
  },
  instructions: {
    textAlign: 'center',
    color: '#333333',
    marginBottom: 5,
  },
});

AppRegistry.registerComponent('LocationDemo', () => LocationDemo);
