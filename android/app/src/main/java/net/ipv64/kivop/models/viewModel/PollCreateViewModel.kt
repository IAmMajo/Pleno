package net.ipv64.kivop.models.viewModel

import androidx.compose.runtime.getValue
import androidx.compose.runtime.mutableStateOf
import androidx.compose.runtime.setValue
import androidx.lifecycle.ViewModel
import java.time.LocalDateTime
import net.ipv64.kivop.dtos.PollServiceDTOs.CreatePollDTO
import net.ipv64.kivop.dtos.PollServiceDTOs.GetPollVotingOptionDTO
import net.ipv64.kivop.services.api.postPollApi

class PollCreateViewModel : ViewModel() {
  var createPoll by
      mutableStateOf<CreatePollDTO>(
          CreatePollDTO(
              question = "",
              description = "",
              closedAt = LocalDateTime.now().plusDays(2),
              anonymous = false,
              multiSelect = false,
              options =
                  listOf(
                      GetPollVotingOptionDTO(index = 1u, text = ""),
                      GetPollVotingOptionDTO(index = 2u, text = ""))))

  fun addOption(text: String) {
    val newIndex = createPoll.options.size.toUByte()
    val newOptions = createPoll.options + GetPollVotingOptionDTO(index = newIndex, text = text)
    createPoll = createPoll.copy(options = newOptions)
  }

  fun removeOption(index: UByte) {
    val newOptions = createPoll.options.filter { it.index != index }
    createPoll = createPoll.copy(options = newOptions)
  }

  fun updateOptionText(index: UByte, text: String) {
    val newOptions = createPoll.options.map { if (it.index == index) it.copy(text = text) else it }
    createPoll = createPoll.copy(options = newOptions)
  }

  fun isPollValid(): Boolean {
    return createPoll.question.isNotBlank() &&
        createPoll.closedAt.isAfter(LocalDateTime.now()) &&
        createPoll.options.all { it.text.isNotBlank() } &&
        createPoll.options.isNotEmpty()
  }

  suspend fun createPoll(): Boolean {
    return postPollApi(createPoll)
  }

  init {}
}
