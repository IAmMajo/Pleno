// MIT No Attribution
// 
// Copyright 2025 KIVoP
// 
// Permission is hereby granted, free of charge, to any person obtaining a copy of this
// software and associated documentation files (the Software), to deal in the Software
// without restriction, including without limitation the rights to use, copy, modify,
// merge, publish, distribute, sublicense, and/or sell copies of the Software, and to
// permit persons to whom the Software is furnished to do so.
// 
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED,
// INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A
// PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT
// HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION
// OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE
// SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

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
