batteryLevel = require 'battery-level';
isCharging = require 'is-charging';
# View to show the battery status in the status bar
class BatteryStatusView extends HTMLDivElement
  tile: null
  backIcon: null
  frontIcon: null
  statusIconContainer: null
  statusText: null
  pollingInterval: 60000

  initialize: (@statusBar) ->
    # set css classes for the root element
    @classList.add('battery-status', 'inline-block')

    # create the status-icon div
    @statusIconContainer = document.createElement 'div'
    # @statusIconContainer.classList.add 'inline-block', 'status', 'unknown'
    @appendChild @statusIconContainer

    # create status-icon spans and put then in the icon container
    @backIcon = document.createElement 'span'
    # @backIcon.classList.add 'back-icon', 'icon-battery-unknown'
    @statusIconContainer.appendChild @backIcon

    @frontIcon = document.createElement 'span'
    # @frontIcon.classList.add 'front-icon', 'icon-battery-unknown'
    @statusIconContainer.appendChild @frontIcon

    # create the status-text span
    @statusText = document.createElement 'span'
    # @statusText.classList.add 'inline-block'
    @appendChild @statusText

    # update the view and start the update cycle
    @updateStatus()
    @startPolling()

  attach: ->
    @tile = @statusBar.addRightTile(priority: 0, item: this)

  destroy: ->
    @tile?.destroy()

  startPolling: ->
    if @interval
      clearInterval @interval

    @interval = setInterval =>
        @updateStatus()
      , @pollingInterval

  updateStatus: ->
    percentage = null;
    # fetch battery percentage and charge status and update the view
    batteryLevel().then (level) =>
      percentage = level * 100
      @updateStatusText(percentage)
    isCharging().then (result) =>
      console.log "risultato:", result
      @updateStatusIcon percentage, result


  updateStatusText: (percentage) ->
    if percentage?
      # display charge of the first battery in percent (no multi battery support
      # as of now)
      @statusText.textContent = "#{percentage}%"
    else
      @statusText.textContent = 'error'
      console.warn "Battery Status: invalid charge value: #{percentage}"

  updateStatusIcon: (percentage, chargeStatus) ->
    if !(chargeStatus?)
      chargeStatus = 'unknown'

    # clear the class list of the status icon element and re-add basic style
    # classes
    @backIcon.className = ''
    @backIcon.classList.add 'back-icon', 'battery-icon'
    @frontIcon.className = ''
    @frontIcon.classList.add 'front-icon', 'battery-icon'
    @statusIconContainer.className = 'status'

    # add style classes according to charge status
    iconClass = 'icon-battery-unknown';

    if chargeStatus == true || percentage == 100
      iconClass = 'icon-battery-charging'
    else if chargeStatus == false
      iconClass = 'icon-battery'

    clip = 'none'
    statusClass = 'unknown'

    if chargeStatus != 'unknown'
      if percentage <= 5 && chargeStatus == false
        iconClass = 'icon-battery-alert'
        statusClass = 'critical'
      else
        if percentage <= 10
          statusClass = 'warning'
        else
          statusClass = 'normal'

        clipFull = 23
        clipEmpty = 86
        clipTop = clipFull + ((100 - percentage) / 100 * (clipEmpty - clipFull))
        clip = "inset(#{clipTop}% 0 0 0)"

    @statusIconContainer.classList.add statusClass
    @backIcon.classList.add iconClass
    @frontIcon.classList.add iconClass

    # cut the front icon from the top using clip-path
    @frontIcon.setAttribute('style', "clip-path: #{clip}; -webkit-clip-path: #{clip};")

  setShowPercentage: (showPercentage) ->
    if showPercentage
      @statusText.removeAttribute 'style'
    else
      @statusText.setAttribute 'style', 'display: none;'

  setOnlyShowInFullscreen: (onlyShowInFullscreen) ->
    if onlyShowInFullscreen
      @classList.add 'hide-outside-fullscreen'
    else
      @classList.remove 'hide-outside-fullscreen'

  setPollingInterval: (pollingInterval) ->
    if pollingInterval
      pollingInterval = Math.max(pollingInterval, 1)
      @pollingInterval = 1000 * pollingInterval
      @startPolling()


module.exports = document.registerElement('battery-level', prototype: BatteryStatusView.prototype)
