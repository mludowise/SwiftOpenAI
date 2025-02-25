//
//  AssistantStreamEvent.swift
//
//
//  Created by James Rochabrun on 3/22/24.
//

import Foundation

/// A model that helps retrieve an object from an event.
public enum AssistantStreamEvent {

   /// Occurs when a new thread is created.
   /// - data is a thread
   case threadCreated(ThreadObject)

   /// Occurs when a new run is created.
   /// - data is a run
   case threadRunCreated(RunObject)

   /// Occurs when a run moves to a queued status.
   /// - data is a run
   case threadRunQueued(RunObject)

   /// Occurs when a run moves to an in_progress status.
   /// - data is a run
   case threadRunInProgress(RunObject)

   /// Occurs when a run moves to a requires_action status.
   /// - data is a run
   case threadRunRequiresAction(RunObject)

   /// Occurs when a run is completed.
   /// - data is a run
   case threadRunCompleted(RunObject)

   /// Occurs when a run fails.
   /// - data is a run
   case threadRunFailed(RunObject)

   /// Occurs when a run moves to a cancelling status.
   /// - data is a run
   case threadRunCancelling(RunObject)

   /// Occurs when a run is cancelled.
   /// - data is a run
   case threadRunCancelled(RunObject)

   /// Occurs when a run expires.
   /// - data is a run
   case threadRunExpired(RunObject)

   /// Occurs when a run step is created.
   /// - data is a run step
   case threadRunStepCreated(RunStepObject)

   /// Occurs when a run step moves to an in_progress state.
   /// - data is a run step
   case threadRunStepInProgress(RunStepObject)

   /// Occurs when parts of a run step are being streamed.
   /// - data is a run step delta
   case threadRunStepDelta(RunStepDeltaObject)

   /// Occurs when a run step is completed.
   /// - data is a run step
   case threadRunStepCompleted(RunStepObject)

   /// Occurs when a run step fails.
   /// - data is a run step
   case threadRunStepFailed(RunStepObject)

   /// Occurs when a run step is cancelled.
   /// - data is a run step
   case threadRunStepCancelled(RunStepObject)

   /// Occurs when a run step expires.
   /// - data is a run step
   case threadRunStepExpired(RunStepObject)

   /// Occurs when a message is created.
   /// - data is a message
   case threadMessageCreated(MessageObject)

   /// Occurs when a message moves to an in_progress state.
   /// - data is a message
   case threadMessageInProgress(MessageObject)

   /// Occurs when parts of a message are being streamed.
   /// - data is a message delta
   case threadMessageDelta(MessageDeltaObject)

   /// Occurs when a message is completed.
   /// - data is a message
   case threadMessageCompleted(MessageObject)

   /// Occurs when a message ends before it is completed.
   /// - data is a message
   case threadMessageIncomplete(MessageObject)

   /// Occurs when an error occurs. This can happen due to an internal server error or a timeout.
   /// - data is an error
   case error(OpenAIErrorResponse)

   /// Occurs when a stream ends.
   /// - data is [DONE]
   case done

}
