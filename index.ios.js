import React, { Component } from 'react'
import pole from 'pole'
import {
  AppRegistry,
  StyleSheet,
  Text,
  View
} from 'react-native'

// Poll location every 3 seconds
const LOCATION_POLL_FREQUENCY = 3 * 1000

export default class LocationDemo extends Component {
  constructor (props) {
    super(props)
    // store reference to location polling object
    this.state = {
      pollLocation: null,
      lastPollTime: null
    }

    this.updateTime = this.updateTime.bind(this)
    //this.updateLocation = this.updateLocation.bind(this)
  }

  componentDidMount () {

    this.setState({
      pollLocation: pole({interval: LOCATION_POLL_FREQUENCY}, (callback) => {
        let now =  new Date()
        let data = JSON.stringify({'lat': 20, 'long': 20, 'time': now })
        fetch('http://localhost:8080', {
          method: 'POST',
          headers: {
            'Accept': 'application/json',
            'Content-Type': 'application/json',
          },
          body: data
        })
        this.updateTime(now)
        callback()
      })
    })
  }

  componentWillUnmount () {
    if (this.state.pollLocation) {
      this.state.pollLocation.cancel()
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
