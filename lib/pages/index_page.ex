defmodule Adanselm.IndexPage do
  use Tableau.Page, layout: Adanselm.RootLayout, permalink: "/"
  use Phoenix.Component

  def template(assigns) do
    ~H"""
    <div class="bg-white py-24 sm:py-32">
    <!-- people... -->
    <div class="mx-auto max-w-7xl px-6 lg:px-8">
        <div class="mx-auto max-w-2xl text-center">
          <h2 class="text-3xl font-bold tracking-tight text-gray-900 sm:text-4xl">About me</h2>
          </div>
          <div class="mx-auto flex flex-col justify-center content-center gap-8 mt-12 mb-16 max-w-2xl lg:max-w-none lg:flex-row">

          <img class="mx-auto lg:mx-0 h-56 w-56 rounded-full" src="/images/20240216_me.jpeg" alt="portrait" />
          <div class="mx-auto lg:mx-0">
                  <h3 class="mt-6 text-base font-semibold leading-7 tracking-tight text-gray-900">Adrien Anselme</h3>
                  <p class="text-sm leading-6 text-gray-600">🤓 Indie hacking dad, Yogi and amateur guitarist</p>
                  <p class="text-sm leading-6 text-gray-600">📍 Toulouse, France</p>
                  <ul role="list" class="mt-6 flex justify-center gap-x-6">
                    <li>
                      <a href="https://twitter.com/adanselm" class="text-gray-400 hover:text-gray-500">
                        <span class="sr-only">X</span>
                        <svg class="h-5 w-5" fill="currentColor" viewBox="0 0 20 20" aria-hidden="true">
                          <path d="M11.4678 8.77491L17.2961 2H15.915L10.8543 7.88256L6.81232 2H2.15039L8.26263 10.8955L2.15039 18H3.53159L8.87581 11.7878L13.1444 18H17.8063L11.4675 8.77491H11.4678ZM9.57608 10.9738L8.95678 10.0881L4.02925 3.03974H6.15068L10.1273 8.72795L10.7466 9.61374L15.9156 17.0075H13.7942L9.57608 10.9742V10.9738Z" />
                        </svg>
                      </a>
                    </li>
                    <li>
                      <a href="https://www.linkedin.com/in/adrien-anselme/" class="text-gray-400 hover:text-gray-500">
                        <span class="sr-only">LinkedIn</span>
                        <svg class="h-5 w-5" fill="currentColor" viewBox="0 0 20 20" aria-hidden="true">
                          <path fill-rule="evenodd" d="M16.338 16.338H13.67V12.16c0-.995-.017-2.277-1.387-2.277-1.39 0-1.601 1.086-1.601 2.207v4.248H8.014v-8.59h2.559v1.174h.037c.356-.675 1.227-1.387 2.526-1.387 2.703 0 3.203 1.778 3.203 4.092v4.711zM5.005 6.575a1.548 1.548 0 11-.003-3.096 1.548 1.548 0 01.003 3.096zm-1.337 9.763H6.34v-8.59H3.667v8.59zM17.668 1H2.328C1.595 1 1 1.581 1 2.298v15.403C1 18.418 1.595 19 2.328 19h15.34c.734 0 1.332-.582 1.332-1.299V2.298C19 1.581 18.402 1 17.668 1z" clip-rule="evenodd" />
                        </svg>
                      </a>
                    </li>
                  </ul>
                  </div>
                  </div>
        </div>

        <div class="mx-auto max-w-7xl px-6 lg:px-8">
        <div class="mx-auto max-w-2xl text-center">
          <h2 class="text-3xl font-bold tracking-tight text-gray-900 sm:text-4xl">Projects</h2>
        </div>
        <ul role="list" class="mx-auto mt-12 mb-16 grid max-w-2xl auto-rows-fr grid-cols-1 gap-8 sm:mt-20 lg:mx-0 lg:max-w-none lg:grid-cols-2">
          <li>
          <a href="https://www.ecohackers.co" class="flex flex-col gap-10 sm:flex-row">
            <img class="aspect-[4/5] w-52 flex-none rounded-2xl object-cover" src="/images/20240216_ecohackers.png" alt="ecohackers illustration">
            <div class="max-w-xl flex-auto">
              <h3 class="text-lg font-semibold leading-8 tracking-tight text-gray-900">EcoHackers</h3>
              <p class="text-base leading-7 text-gray-600">Newsletter</p>
              <p class="mt-6 text-base leading-7 text-gray-600">I've been working from home for a very long time. Turns out it's one of the actions you can take to be more eco-friendly as a developer. I decided to write about what more we can do in a newsletter.</p>
            </div>
            </a>
          </li>

          <li>
          <a href="https://springbeats.com/velpro" class="flex flex-col gap-10 sm:flex-row">
            <img class="aspect-[4/5] w-52 flex-none rounded-2xl object-cover" src="/images/20190412_velpro1_screenshot.png" alt="velpro illustration">
            <div class="max-w-xl flex-auto">
              <h3 class="text-lg font-semibold leading-8 tracking-tight text-gray-900">Velpro</h3>
              <p class="text-base leading-7 text-gray-600">Mac and Windows app</p>
              <p class="mt-6 text-base leading-7 text-gray-600">Change the velocity of your MIDI instruments. VelPro lets you create a custom velocity response curve for each note of your keyboard.</p>
            </div>
            </a>
          </li>


        </ul>
      </div>

      <!-- blog... -->
      <div class="mx-auto max-w-7xl px-6 lg:px-8">
        <div class="mx-auto max-w-2xl text-center">
          <h2 class="text-3xl font-bold tracking-tight text-gray-900 sm:text-4xl">From the blog</h2>
          <p class="my-2 text-sm leading-6 text-gray-600">⚠️ Opinions expressed here are my own ⚠️</p>
          <p class="text-sm leading-6 text-gray-400">Some old articles are technically outdated but I kept them to show how much of a visionary Elixir early adopter I was... 😬</p>
        </div>
        <div class="mx-auto mt-16 grid max-w-2xl auto-rows-fr grid-cols-1 gap-8 sm:mt-20 lg:mx-0 lg:max-w-none lg:grid-cols-3">

          <article :for={post <- @posts} class="relative isolate flex flex-col justify-end overflow-hidden rounded-2xl bg-gray-900 px-8 pb-8 pt-80 sm:pt-48 lg:pt-80">
            <img src={post.thumbnail} alt="" class="absolute inset-0 -z-10 h-full w-full object-cover">
            <div class="absolute inset-0 -z-10 bg-gradient-to-t from-gray-900 via-gray-900/40"></div>
            <div class="absolute inset-0 -z-10 rounded-2xl ring-1 ring-inset ring-gray-900/10"></div>

            <div class="flex flex-wrap items-center gap-y-1 overflow-hidden text-sm leading-6 text-gray-300">
              <time datetime={post.date |> NaiveDateTime.to_date |> Date.to_iso8601} class="mr-8"><%= post.date |> NaiveDateTime.to_date |> Date.to_iso8601 %></time>
            </div>
            <h3 class="mt-3 text-xl font-semibold leading-6 text-white">
              <a href={post.permalink}>
                <span class="absolute inset-0"></span>
                <%= post.title %>
              </a>
            </h3>
          </article>

        </div>
      </div>
    </div>
    """
  end
end
