import MetricKit
import SwiftRex

public enum MetricKitAction {
    case start
    case stop
    case receivePayloads([Data])
    case logBegin(category: String, name: StaticString)
    case logEvent(category: String, name: StaticString)
    case logEnd(category: String, name: StaticString)
}

public class MetricKitMiddleware: Middleware {
    public typealias InputActionType = MetricKitAction
    public typealias OutputActionType = MetricKitAction
    public typealias StateType = Void
    private var output: AnyActionHandler<MetricKitAction>?
    private var metricsSubscriber: Subscriber?
    private var logHandlers: [String: OSLog] = [:]
    private let onPayloads: ([Data]) -> Void

    public init(onPayloads: @escaping ([Data]) -> Void = { _ in }) {
        self.onPayloads = onPayloads
    }

    public func receiveContext(getState: @escaping GetState<Void>, output: AnyActionHandler<MetricKitAction>) {
        self.output = output
    }

    public func handle(action: MetricKitAction, from dispatcher: ActionSource, afterReducer: inout AfterReducer) {
        guard let output = self.output else { return }

        switch action {
        case .start:
            let subscriber = Subscriber { payloads in
                output.dispatch(.receivePayloads(payloads.map { $0.jsonRepresentation() } ))
            }
            MXMetricManager.shared.add(subscriber)
            self.metricsSubscriber = subscriber
        case .stop:
            guard let subscriber = self.metricsSubscriber else { return }
            MXMetricManager.shared.remove(subscriber)
            metricsSubscriber = nil
        case let .logBegin(category, name):
            mxSignpost(.begin, log: handler(for: category), name: name)
        case let .logEvent(category, name):
            mxSignpost(.event, log: handler(for: category), name: name)
        case let .logEnd(category, name):
            mxSignpost(.end, log: handler(for: category), name: name)
        case let .receivePayloads(payloads):
            onPayloads(payloads)
        }
    }

    private func handler(for category: String) -> OSLog {
        logHandlers[category] ?? {
            let newLogger = MXMetricManager.makeLogHandle(category: category)
            logHandlers[category] = newLogger
            return newLogger
        }()
    }

    class Subscriber: NSObject, MXMetricManagerSubscriber {
        private let onPayloads: ([MXMetricPayload]) -> Void

        init(onPayloads: @escaping ([MXMetricPayload]) -> Void) {
            self.onPayloads = onPayloads
        }

        func didReceive(_ payloads: [MXMetricPayload]) {
            onPayloads(payloads)
        }
    }
}
