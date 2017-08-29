package de.frosner.broccoli.nomad

import cats.instances.future._
import de.frosner.broccoli.nomad.models._
import shapeless.tag.@@
import squants.Quantity
import squants.information.Information

import scala.collection.immutable
import scala.concurrent.ExecutionContext

/**
  * A client for Nomad.
  */
trait NomadClient {

  /**
    * The execution context for actions of this client.
    */
  implicit def executionContext: ExecutionContext

  /**
    * Get allocations for a job.
    *
    * @param jobId The ID of the job
    * @return The list of allocations for the job
    */
  def getAllocationsForJob(jobId: String @@ Job.Id): NomadT[WithId[immutable.Seq[Allocation]]]

  /**
    * Get an allocation.
    *
    * @param id The alloction to query
    * @return The allocation or an error
    */
  def getAllocation(id: String @@ Allocation.Id): NomadT[Allocation]

  /**
    * Get a node.
    *
    * @param id The node to query
    * @return The node data
    */
  def getNode(id: String @@ Node.Id): NomadT[Node]

  /**
    * Get a client to access a specific Nomad node.
    *
    * @param node The node to access
    * @return A client to access the given node.
    */
  def nodeClient(node: Node): NomadNodeClient

  /**
    * Run a block on the node of an allocation.
    *
    * @param allocation The allocation
    * @param action The action to execute
    * @tparam R The result of the action
    * @return The result of the action, or any nomad error
    */
  def onAllocationNode[R](allocation: Allocation)(action: NomadNodeClient => NomadT[R]): NomadT[R] =
    for {
      node <- getNode(allocation.nodeId)
      result <- action(nodeClient(node))
    } yield result
}

/**
  * A client for Nomad nodes.
  *
  * These actions need to be invoked directly on a particular node, ie, require to obtain access to a node first.
  */
trait NomadNodeClient {

  /**
    * Get the log of a task on an allocation.
    *
    * @param allocationId The ID of the allocation
    * @param taskName The name of the task
    * @param stream The kind of log to fetch
    * @param offset The number of bytes to fetch from the end of the log.  If None fetch the entire log
    * @return The task log
    */
  def getTaskLog(
      allocationId: String @@ Allocation.Id,
      taskName: String @@ Task.Name,
      stream: LogStreamKind,
      offset: Option[Quantity[Information] @@ TaskLog.Offset]
  ): NomadT[TaskLog]
}
