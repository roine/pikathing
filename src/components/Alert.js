export default function Alert (props) {
  console.log(props)
  if (props.state.location && props.state.location.state && props.state.location.state.alert) {
    return props.state.location.state.alert;
  }
  else{
    return null;
  }
}