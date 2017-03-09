BatteryStatusView = require './battery-status-view'
{CompositeDisposable} = require 'atom'

module.exports = BatteryStatus =
  batteryStatusView: null
  disposables: null

  activate: ->

  deactivate: ->
    @batteryStatusView?.destroy()
    @batteryStatusView = null
    @disposables?.dispose()

  consumeStatusBar: (statusBar) ->
    @batteryStatusView = new BatteryStatusView()
    @batteryStatusView.initialize(statusBar)
    @batteryStatusView.attach()
