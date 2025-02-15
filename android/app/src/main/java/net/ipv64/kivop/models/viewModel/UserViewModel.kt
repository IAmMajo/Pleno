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
import androidx.lifecycle.viewModelScope
import java.util.UUID
import kotlinx.coroutines.launch
import net.ipv64.kivop.dtos.AuthServiceDTOs.UserProfileDTO
import net.ipv64.kivop.dtos.AuthServiceDTOs.UserProfileUpdateDTO
import net.ipv64.kivop.services.api.getUserProfile
import net.ipv64.kivop.services.api.patchUserProfile

class UserViewModel : ViewModel() {
  private var user by mutableStateOf<UserProfileDTO?>(null)
    private set

  fun fetchUser() {
    viewModelScope.launch {
      val response = getUserProfile() // Call the API service to get user profile
      response?.let { user = it } // Set the user profile in ViewModel state
    }
  }

  fun getProfile(): UserProfileDTO? {
    return this.user
  }

  fun getID(): UUID? {
    return this.user?.uid
  }

  fun updateUser(
      email: String? = null,
      name: String? = null,
      profileImage: String? = null,
      isNotificationsActive: Boolean? = null,
      isPushNotificationsActive: Boolean? = null
  ) {
    user?.let {
      val updatedUser =
          it.copy(
              email = email ?: it.email,
              name = if (name?.isNotEmpty() == true) name else it.name,
              profileImage = profileImage ?: it.profileImage,
              isNotificationsActive = isNotificationsActive ?: it.isNotificationsActive,
              isPushNotificationsActive = isPushNotificationsActive ?: it.isPushNotificationsActive)
      if (updatedUser != it) {
        viewModelScope.launch {
          val response =
              patchUserProfile(
                  UserProfileUpdateDTO(
                      name = if (name.isNullOrEmpty()) null else name,
                      profileImage,
                      isNotificationsActive,
                      isPushNotificationsActive),
              )
          if (response?.isSuccessful == true) {
            user = updatedUser
          }
        }
      }
    }
  }

  init {}
}
